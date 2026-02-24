# AP Pet System (with K9 Support)

![Banner Image](https://i.imgur.com/dZLw5fz.png)

An advanced Pet System for FiveM servers, supporting both QBCore and ESX frameworks (Autodetect). This script allows players to buy, care for (feed/water), and interact with their pets. It also features a fully functional K9 unit system for Police officers (Drug Sniffing & Attacking).

## 🚀 Key Features

- **Dual Framework:** Built-in support for QBCore and ESX.
- **Target System:** Supports both `ox_target` and `qb-target`.
- **Multi-Language (Locale):** Supports English (`en`) and Indonesian (`id`).
- **Needs System:** Pets have hunger, thirst, and health that deplete over time.
- **Custom UI / UI Bridge:** Supports `ox_lib`, `qb-menu`, and `lation_ui` for a modern interface. Displays detailed pet status (Health, Hunger, Thirst, Status) on the screen.
- **Healing & Revive System:** Players can use medkits to heal their pets, or revivers if the pet dies.
- **K9 Exclusive Actions:** Contraband (illegal items) checking and target attacking for K9 Police units.
- **Low Resmon:** Highly optimized script utilizing modern target systems and efficient event management.

## � Previews

### Pet HUD & Status

![Pet HUD](https://i.imgur.com/ANloQ2N.png)

### Pet Menu & Interaction

![Pet Menu](https://i.imgur.com/W4prQnI.png)

### Pet Shop Menu

![Pet Shop Menu](https://i.imgur.com/OEGUJuo.png)

### K9 Action (Attack & Sniff)

![K9 Action](https://i.imgur.com/s7GiV0E.png)

## �📋 Dependencies (Required)

Ensure the following resources are installed and running on your server:

1. `oxmysql` (Required for the database)
2. `ox_lib` (Required for UI Menus, Notifications, Progressbars)
3. UI System: `lation_ui` (Optional, supported via bridge)
4. Framework: `qb-core` OR `es_extended`
5. Target: `ox_target` OR `qb-target`

## ⚙️ Installation

1. Download or move the `ap_pet` folder into your server's `resources` directory.
2. Run the `ap_pet.sql` file in your server's database. This will create the `player_pets` table.
3. Add the required items to your framework (Guide below).
4. Ensure you have the item icons in your inventory's image folder (`ox_inventory/web/images` or `qb-inventory/html/img`).
5. Add `ensure ap_pet` to your `server.cfg`. Make sure it is placed AFTER `ox_lib` and `oxmysql`.
6. Configure the script to your liking in the `config.lua` file (Language, Prices, Target System, etc.).

## 🧳 Required Items (Crucial!)

You MUST register the following items in your core framework/inventory for the Feeding and Healing systems to work:

### For QBCore / ox_inventory (QBX)

Open your `qb-core/shared/items.lua` (or `ox_inventory/data/items.lua` if using ox) and add the following items:

```lua
-- AP Pet Items
['pet_medkit']   = {['name'] = 'pet_medkit', ['label'] = 'Pet Medkit', ['weight'] = 500, ['type'] = 'item', ['image'] = 'pet_medkit.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'A first aid kit to heal an injured pet.'},
['pet_revive']   = {['name'] = 'pet_revive', ['label'] = 'Pet Revive', ['weight'] = 200, ['type'] = 'item', ['image'] = 'pet_revive.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'An adrenaline syringe to revive a dead pet.'},
['pet_food']     = {['name'] = 'pet_food', ['label'] = 'Pet Food', ['weight'] = 200, ['type'] = 'item', ['image'] = 'pet_food.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Some tasty food for your pet.'},
['pet_water']    = {['name'] = 'pet_water', ['label'] = 'Pet Water', ['weight'] = 200, ['type'] = 'item', ['image'] = 'pet_water.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'A bowl of water for your pet.'},
```

## 🐾 Commands & Menus

- Use the `/pet` command to open the Main Pet Menu.
- Buy a pet first via the "Pet Shop" menu.
- K9 Police officers can get K9 pets for free.
- Dead pets will be marked with a "☠️ (Dead)" tag. Click on their name to either revive them or discard them permanently.

## 🚓 K9 Contraband System

When a K9 dog sniffs another player, the script checks the target's inventory for illegal items.
The list of illegal items can be edited in `config.lua` under the `Config.ContrabandItems` table:

```lua
Config.ContrabandItems = {
    'weed', 'weed_pooch', 'coke', 'coke_pooch', 'meth', 'meth_pooch',
    'kq_meth_low', 'kq_meth_mid', 'kq_meth_high',
    'kq_weed_joint_og_kush', 'kq_weed_joint_purple_haze', 'kq_weed_joint_white_widow', 'kq_weed_joint_blue_dream'
}
```

Add or remove illegal item names based on your server's items!

## 📸 Adding New Pets

You can add other dog/cat ped models (e.g., custom Husky mod, Pug, etc.) by registering them in the `Config.AvailablePets` table in `config.lua`.

```lua
['rottweiler'] = { model = 'a_c_rottweiler', name = 'Rottweiler', price = 5000, type = 'civilian', canSit = true },
```
