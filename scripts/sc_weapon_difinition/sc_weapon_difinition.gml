/// @desc Immutable weapon data shared by player and enemy weapons.
/// @param {struct} _config Named weapon settings. Only add new fixed data here.
function create_weapon_definition(_config) constructor
{
    id        = variable_struct_exists(_config, "id") ? _config.id : "";
    name      = variable_struct_exists(_config, "name") ? _config.name : "";
    sprite    = variable_struct_exists(_config, "sprite") ? _config.sprite : noone;
    icon      = variable_struct_exists(_config, "icon") ? _config.icon : sprite;
    length    = variable_struct_exists(_config, "length") ? _config.length : 0;

    bullet    = variable_struct_exists(_config, "bullet") ? _config.bullet : noone;
    cooldown  = variable_struct_exists(_config, "cooldown") ? _config.cooldown : 30;
    bulletNum = variable_struct_exists(_config, "bulletNum") ? _config.bulletNum : 1;
    spread    = variable_struct_exists(_config, "spread") ? _config.spread : 0;
    damage    = variable_struct_exists(_config, "damage") ? _config.damage : 10;
    automatic = variable_struct_exists(_config, "automatic") ? _config.automatic : false;

    magSize     = variable_struct_exists(_config, "magSize") ? _config.magSize : 12;
    reserveAmmo = variable_struct_exists(_config, "reserveAmmo") ? _config.reserveAmmo : 120;
    reloadTime  = variable_struct_exists(_config, "reloadTime") ? _config.reloadTime : room_speed;

    fireSound   = variable_struct_exists(_config, "fireSound") ? _config.fireSound : noone;
    reloadSound = variable_struct_exists(_config, "reloadSound") ? _config.reloadSound : noone;
    emptySound  = variable_struct_exists(_config, "emptySound") ? _config.emptySound : noone;
}
