# Density Management NUI Menu (Pro/FR-EN) FiveM

**ENGLISH BELOW**

## 🇫🇷 Description  
Menu NUI moderne et épuré pour régler en live la densité des véhicules, piétons, garés, policiers, etc.  
- Compatible ESX, QBCore et Standalone  
- Support multilingue live FR/EN (menu déroulant, UI)
- Densité sauvegardée par joueur en base SQL (ou globale)
- Auto-wipe véhicules si trop de joueurs (configurable)
- Interface responsive, pro, sans bug d’apparition/suppression
- Quand tu mets un slider à 0 : tout ce type disparaît
- Quand tu remets >0 : spawn naturel et fluide (pas de blocage !)

### Installation

1. **Copier tout le dossier** dans `resources/[admin]/menu_traffic`
2. **Créer la table SQL** :
    ```sql
    CREATE TABLE IF NOT EXISTS density_settings (
        identifier VARCHAR(64) PRIMARY KEY,
        vehicle FLOAT DEFAULT 1.0,
        parked FLOAT DEFAULT 1.0,
        ped FLOAT DEFAULT 1.0,
        scene FLOAT DEFAULT 1.0,
        police FLOAT DEFAULT 1.0
    );
    ```
3. **Renseigner/configurer `config.lua`** selon vos besoins (langue, densité, suppression auto véhicules si besoin)
4. **Ajouter à votre `server.cfg` ** :
    ```
    ensure menu_traffic
    ```
5. **F9** pour ouvrir (fondateur uniquement, configurable)
6. **Change les valeurs -> sauvegarde en DB, se recharge au login/menu**

---

## 🇬🇧 Description  
Modern & minimal NUI menu to adjust densities of vehicles, peds, parked, police etc. in real time.  
- ESX, QBCore and Standalone compatible  
- Live multilingual FR/EN support (dropdown in UI)
- Per-player density saved to SQL DB (or global if STANDALONE)
- Auto-wipe vehicles if too many players (configurable)
- Responsive, professional interface — never glitches if you reload/spawn after wipe!
- Set slider to 0: all entities of that type are deleted
- Set slider >0: natural GTA/FiveM spawning resumes instantly

### Installation

1. **Place the folder** into `resources/[admin]/menu_traffic`
2. **Create SQL table** :
    ```sql
    CREATE TABLE IF NOT EXISTS density_settings (
        identifier VARCHAR(64) PRIMARY KEY,
        vehicle FLOAT DEFAULT 1.0,
        parked FLOAT DEFAULT 1.0,
        ped FLOAT DEFAULT 1.0,
        scene FLOAT DEFAULT 1.0,
        police FLOAT DEFAULT 1.0
    );
    ```
3. **Edit `config.lua`** as you want (languages, densities, auto-wipe setting)
4. **Add in your `server.cfg` **:
    ```
    ensure menu_traffic
    ```
5. **F9** to open (founder-only, changeable)
6. **Change values → instant save → auto-restores at reconnect / menu open**

---

**Any issue or improvement wanted? Contact atzcpp!**
